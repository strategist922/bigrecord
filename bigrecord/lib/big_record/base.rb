## The sub-classes of this class must implement the abstract method 'column_names' of this class.
module BigRecord
  class BigRecordError < StandardError #:nodoc:
  end
  class SubclassNotFound < BigRecordError #:nodoc:
  end
  class AssociationTypeMismatch < BigRecordError #:nodoc:
  end
  class WrongAttributeDataType < BigRecordError #:nodoc:
  end
  class AttributeMissing < BigRecordError #:nodoc:
  end
  class UnknownAttribute < BigRecordError #:nodoc:
  end
  class AdapterNotSpecified < BigRecordError # :nodoc:
  end
  class AdapterNotFound < BigRecordError # :nodoc:
  end
  class ConnectionNotEstablished < BigRecordError #:nodoc:
  end
  class ConnectionFailed < BigRecordError #:nodoc:
  end
  class RecordNotFound < BigRecordError #:nodoc:
  end
  class RecordNotSaved < BigRecordError #:nodoc:
  end
  class StatementInvalid < BigRecordError #:nodoc:
  end
  class PreparedStatementInvalid < BigRecordError #:nodoc:
  end
  class StaleObjectError < BigRecordError #:nodoc:
  end
  class ConfigurationError < StandardError #:nodoc:
  end
  class ReadOnlyRecord < StandardError #:nodoc:
  end
  class NotImplemented < BigRecordError #:nodoc:
  end
  class ColumnNotFound < BigRecordError #:nodoc:
  end

  class Base < AbstractBase

    attr_accessor :modified_attributes

    def self.inherited(child) #:nodoc:
      @@subclasses[self] ||= []
      @@subclasses[self] << child
      child.set_table_name child.name.tableize if child.superclass == BigRecord::Base
      super
    end

    # New objects can be instantiated as either empty (pass no construction parameter) or pre-set with
    # attributes but not yet saved (pass a hash with key names matching the associated table column names).
    # In both instances, valid attribute keys are determined by the column names of the associated table --
    # hence you can't have attributes that aren't part of the table columns.
    def initialize(attrs = nil)
      @new_record = true
      super
      @modified_attributes ||= {}
      if attrs
        attrs.each do |k,v|
          @modified_attributes[k] = v.hash
          set_loaded(k)
        end
      end
    end

    def deserialize(attrs = nil)
      @modified_attributes ||= {}
      if attrs
        attrs.each { |k,v| @modified_attributes[k] = v.hash}
        attrs.each do |k,v|
          begin
            attrs[k] =
            if k == "attribute:id"
              v
            elsif v.is_a?(Array)
              v.collect do |e|
                YAML::load(e)
              end
            else
              YAML::load(v) if v
            end
          rescue Exception => e
            puts "#{k}"
            puts "#{v} #{v.class}"
            puts e.message
            puts e.backtrace.join("\n")
          end
        end
      end
    end

    # Returns the value of the attribute identified by <tt>attr_name</tt> after it has been typecast (for example,
    # "2004-12-12" in a data column is cast to a date object, like Date.new(2004, 12, 12)).
    # (Alias for the protected read_attribute method).
    def [](attr_name)
      if attr_name.ends_with?(":")
        read_family_attributes(attr_name)
      else
        read_attribute(attr_name)
      end
    end

#  protected
    # Returns the value of the attribute identified by <tt>attr_name</tt> after it has been typecast (for example,
    # "2004-12-12" in a data column is cast to a date object, like Date.new(2004, 12, 12)).
    def read_attribute(attr_name, options={})
      attr_name = attr_name.to_s
      column = column_for_attribute(attr_name)
      if column
        # First check if the attribute is already in the attributes hash
        if @attributes.has_key?(attr_name) and options.blank?
          super(attr_name)
        # Elsif the column exist, we try to lazy load it
        elsif !(is_loaded?(attr_name)) and attr_name != self.class.primary_key and !new_record?
          unless self.all_attributes_loaded? and attr_name =~ /\Aattribute:/
            if options.blank?
              # Normal behavior

              # Retrieve the version of the attribute matching the current record version
              options[:timestamp] = self.updated_at.to_hbase_timestamp if self.has_attribute?('attribute:updated_at') and self.updated_at

              # get the content of the cell
              value = connection.get_raw(self.class.table_name, self.id, attr_name, options)

              set_loaded(attr_name)
              value_no_yaml =
              if attr_name == "attribute.id"
                value
              elsif value.is_a?(Array)
                value.collect{|e| YAML::load(e)}
              else
                YAML::load(value) if value
              end
              write_attribute(attr_name, column.type_cast(value_no_yaml))
            else
              # Special request... don't keep it in the attributes hash
              options[:timestamp] ||= self.updated_at.to_hbase_timestamp if self.has_attribute?('attribute:updated_at') and self.updated_at

              # get the content of the cell
              value = connection.get_raw(self.class.table_name, self.id, attr_name, options)

              if options[:num_versions] and options[:num_versions] > 1
                value.collect do |v|
                  value_no_yaml = v.is_a?(Array) ? v.collect{|e| YAML::load(e)} : YAML::load(v)
                  column.type_cast(value_no_yaml)
                end
              else
                value_no_yaml = value.is_a?(Array) ? value.collect{|e| YAML::load(e)} : YAML::load(value)
                column.type_cast(value_no_yaml)
              end
            end
          else
            write_attribute(attr_name, column.default)
          end
        else
          write_attribute(attr_name, column.default)
        end
      else
        nil
      end
    end

    def read_family_attributes(attr_name)
      attr_name = attr_name.to_s
      column = column_for_attribute(attr_name)
      if column
        # First check if the attribute is already in the attributes hash
        if @attributes.has_key?(attr_name)
          if (values = @attributes[attr_name]) and values.is_a?(Hash)
            values.delete(self.class.primary_key)
            casted_values = {}
            values.each{|k,v| casted_values[k] = column.type_cast(v)}
            write_attribute(attr_name, casted_values)
          else
            write_attribute(attr_name, {})
          end

        # Elsif the column exist, we try to lazy load it
        elsif !(is_loaded?(attr_name)) and attr_name != self.class.primary_key and !new_record?
          unless self.all_attributes_loaded? and attr_name =~ /\Aattribute:/
            options = {}
            # Retrieve the version of the attribute matching the current record version
            options[:timestamp] = self.updated_at.to_hbase_timestamp if self.has_attribute?('attribute:updated_at') and self.updated_at
            @modified_attributes ||= {}
            # get the content of the whole family
            values = connection.get_columns_raw(self.class.table_name, self.id, [attr_name], options)
            if values
              values.delete(self.class.primary_key)
              casted_values = {}
              values.each do |k,v|
                @modified_attributes[k] = v.hash
                value =  v ? YAML::load(v): nil
                short_name = k.split(":")[1]
                casted_values[short_name] =  column.type_cast(value) if short_name
                set_loaded(k)
                write_attribute(k, value) if short_name
              end
              write_attribute(attr_name, casted_values)
            else
              set_loaded(attr_name)
              write_attribute(attr_name, {})
            end
          else
            write_attribute(attr_name, column.default)
          end
        else
          write_attribute(attr_name, column.default)
        end
      else
        nil
      end
    end

    def set_loaded(name)
      @loaded_columns ||= []
      @loaded_columns << name
    end

    def is_loaded?(name)
      @loaded_columns ||= []
      @loaded_columns.include?(name)
    end

  public
    # Returns true if this object hasn't been saved yet -- that is, a record for the object doesn't exist yet.
    def new_record?
      @new_record
    end

    # * No record exists: Creates a new record with values matching those of the object attributes.
    # * A record does exist: Updates the record with values matching those of the object attributes.
    def save
      create_or_update
    end

    # Attempts to save the record, but instead of just returning false if it couldn't happen, it raises a
    # RecordNotSaved exception
    def save!
      create_or_update || raise(RecordNotSaved)
    end

    # Deletes the record in the database and freezes this instance to reflect that no changes should
    # be made (since they can't be persisted).
    def destroy
      unless new_record?
        connection.delete(self.class.table_name, self.id)
      end

      # FIXME: this currently doesn't work because we write the attributes everytime we read them
      # which means that we cannot read the attributes of a deleted record... it's bad
#      freeze
    end

    # Updates a single attribute and saves the record. This is especially useful for boolean flags on existing records.
    # Note: This method is overwritten by the Validation module that'll make sure that updates made with this method
    # doesn't get subjected to validation checks. Hence, attributes can be updated even if the full object isn't valid.
    def update_attribute(name, value)
      send(name.to_s + '=', value)
      save
    end

    # Updates all the attributes from the passed-in Hash and saves the record. If the object is invalid, the saving will
    # fail and false will be returned.
    def update_attributes(attributes)
      self.attributes = attributes
      save
    end

    # Updates an object just like Base.update_attributes but calls save! instead of save so an exception is raised if the record is invalid.
    def update_attributes!(attributes)
      self.attributes = attributes
      save!
    end

    def connection
      self.class.connection
    end

  protected

    def create_or_update
      raise ReadOnlyRecord if readonly?
      result = new_record? ? create : update
      result != false
    end

    # Creates a record with values matching those of the instance attributes
    # and returns its id. Generate a UUID as the row key.
    def create
      self.id = generate_new_id unless self.id
      @new_record = false
      update_hbase
    end

    # Updates the associated record with values matching those of the instance attributes.
    # Returns the number of affected rows.
    def update
      update_hbase
    end

    # Update this record in hbase. Cannot be directly in the method 'update' because it would trigger callbacks and
    # therefore weird behaviors.

    # KEEP THE COMMENTED DEBUG IN THERE, IT HELPS A LOT!
    def update_hbase
      timestamp = self.respond_to?(:updated_at) ? self.updated_at.to_hbase_timestamp : Time.now.to_hbase_timestamp
      # Initialize it if it wasn't up to now
      @modified_attributes ||= {}
#      @attributes.each { |key, value|  puts "echoing #{key} #{value}" }
      data = clone_in_persistence_format
      serialized_content = {}
      data.each {|k,v| serialized_content[k] = v.to_yaml }
      # Reject if
      # - Old value is nil and new value is too or
      # - Both hash are equals
      #puts "modified size #{@modified_attributes.length}"
#      serialized_content.each { |k,v| puts "#{k} (#{v.nil?} && #{@modified_attributes[k].nil?}) || (#{!v.nil?} && #{!@modified_attributes[k].nil?} && #{v.hash} == #{@modified_attributes[k]})}"}
      serialized_content.reject! {|k,v| (v.nil? && @modified_attributes[k].nil?) || (!v.nil? && !@modified_attributes[k].nil? && v.hash == @modified_attributes[k]) }

      if self.respond_to?(:change_log)
        # Build the change log from the remaining keys and clean it
        change_log = serialized_content.keys.to_a
        change_log.delete("attribute:updated_by_id")
        change_log.delete("attribute:updated_at")
        change_log.delete("attribute:model_version")
        change_log.delete("attribute:related_types")
        change_log.delete("log:change")

        #Finally put the change log in data and in the attributes for further gets
        serialized_content["log:change"] = change_log.to_yaml
        @attributes["log:change"] = change_log
       end
#      puts "==="
#      serialized_content.each { |key, value|  puts "saving #{key} #{value}" }
#      puts "==="
      connection.update_raw(self.class.table_name, id, serialized_content, timestamp)
      @modified_attributes.clear
    end

  public
    class << self

      def default_family
        "attribute"
      end

      def primary_key
        @primary_key ||= "#{default_family}:id"
      end

      # HBase scanner utility -- scans the table and executes code on each record
      # Example:
      #    Entity.scan(:batch_size => 200) {|e|puts "#{e.name} is a child!" if e.parent}
      #
      # Parameters:
      #    batch_size - number of records to retrieve from database with each scan iteration.
      #    code - the code to execute (see example above for syntax)
      #
      def scan(options={}, &code)
        options = options.dup
        limit = options.delete(:batch_size) || 100

        items_processed = 0

        # add an extra record for defining the next offset without duplicating records
        limit += 1
        last_row_id = nil

        while true
          items = find(:all, options.merge({:limit => limit, :bypass_index => true}))

          # set the new offset as the extra record
          unless items.empty?
            items.delete_at(0) if items[0].id == last_row_id

            break if items.empty?

            last_row_id = items.last.id
            options[:offset] = last_row_id
            items_processed += items.size

            items.each do |item|
              code.call(item)
            end
          else
            break
          end
        end
      end

      def find(*args)
        options = extract_options_from_args!(args)
        validate_find_options(options)

        # set a default view
        if options[:view]
          options[:view] = options[:view].to_sym
        else
          options[:view] = :default
        end

        if options[:bypass_index]
          case args.first
            when :first then find_every_from_hbase(options.merge({:limit => 1})).first
            when :all   then find_every_from_hbase(options)
            else             find_from_ids(args, options)
          end
        else
          case args.first
            when :first then find_every_from_index(options.merge({:limit => 1})).first
            when :all   then find_every_from_index(options)
            else             find_from_ids(args, options)
          end
        end
      end

      # Returns true if the given +id+ represents the primary key of a record in the database, false otherwise.
      def exists?(id)
        !find(id).nil?
      rescue BigRecord::BigRecordError
        false
      end

      # Creates an object, instantly saves it as a record (if the validation permits it), and returns it. If the save
      # fails under validations, the unsaved object is still returned.
      def create(attrs = nil)
        if attrs.is_a?(Array)
          attrs.collect { |attr| create(attr) }
        else
          object = new(attrs)
          object.save
          object
        end
      end

      # Finds the record from the passed +id+, instantly saves it with the passed +attributes+ (if the validation permits it),
      # and returns it. If the save fails under validations, the unsaved object is still returned.
      #
      # The arguments may also be given as arrays in which case the update method is called for each pair of +id+ and
      # +attributes+ and an array of objects is returned.
      #
      # Example of updating one record:
      #   Person.update(15, {:user_name => 'Samuel', :group => 'expert'})
      #
      # Example of updating multiple records:
      #   people = { 1 => { "first_name" => "David" }, 2 => { "first_name" => "Jeremy"} }
      #   Person.update(people.keys, people.values)
      def update(id, attributes)
        if id.is_a?(Array)
          idx = -1
          id.collect { |a| idx += 1; update(a, attributes[idx]) }
        else
          object = find(id)
          object.update_attributes(attributes)
          object
        end
      end

      # Deletes the record with the given +id+ without instantiating an object first. If an array of ids is provided, all of them
      # are deleted.
      def delete(id)
        if id.is_a?(Array)
          id.each { |a| connection.delete(table_name, a) }
        else
          connection.delete(table_name, id)
        end
      end

      # Destroys the record with the given +id+ by instantiating the object and calling #destroy (all the callbacks are the triggered).
      # If an array of ids is provided, all of them are destroyed.
      def destroy(id)
        id.is_a?(Array) ? id.each { |a| destroy(a) } : find(id).destroy
      end

      # Updates all records with the SET-part of an SQL update statement in +updates+ and returns an integer with the number of rows updated.
      # A subset of the records can be selected by specifying +conditions+. Example:
      #   Billing.update_all "category = 'authorized', approved = 1", "author = 'David'"
      def update_all(updates, conditions = nil)
        raise NotImplemented, "update_all"
      end

      # Destroys the objects for all the records that match the +condition+ by instantiating each object and calling
      # the destroy method. Example:
      #   Person.destroy_all "last_login < '2004-04-04'"
      def destroy_all(conditions = nil)
        find(:all, :conditions => conditions).each { |object| object.destroy }
      end

      # Deletes all the records that match the +condition+ without instantiating the objects first (and hence not
      # calling the destroy method). Example:
      #   Post.delete_all "person_id = 5 AND (category = 'Something' OR category = 'Else')"
      #
      # TODO: take into consideration the conditions
      def delete_all(conditions = nil)
        connection.get_consecutive_rows(table_name, nil, nil, ["attribute:"]).each do |row|
          connection.delete(table_name, row['attribute:id'])
        end
      end

      # Truncate the table for this model
      def truncate
        delete_all
      end

      def table_name
        (superclass == HbaseRecord::Base) ? @table_name : superclass.table_name
      end

      def set_table_name(name)
        @table_name = name.to_s
      end

      def base_class
        (superclass == HbaseRecord::Base) ? self : superclass.base_class
      end

      def view(name, columns)
        name = name.to_sym
        @views_hash ||= default_views

        # The other variables that are cached and depend on @views_hash need to be reloaded
        invalidate_views

        @views_hash[name] = ConnectionAdapters::View.new(name, columns, self)
      end

      def views
        @views ||= views_hash.values
      end

      def view_names
        @view_names ||= views_hash.keys
      end

      def views_hash
        unless @all_views_hash
          # add default hbase columns
          @all_views_hash =
            if self == BigRecord::Base # stop at Base
               @views_hash = default_views
            else
              if @views_hash
                superclass.views_hash.merge(default_views).merge(@views_hash)
              else
                superclass.views_hash.merge(default_views)
              end
            end
        end
        @all_views_hash
      end

      def default_columns
        {primary_key => ConnectionAdapters::Column.new(primary_key, 'string')}
      end

      def default_views
        {:all=>ConnectionAdapters::View.new('all', nil, self), :default=>ConnectionAdapters::View.new('default', nil, self)}
      end

    protected
      def invalidate_views
        @views = nil
        @view_names = nil
      end

      def extract_options_from_args!(args) #:nodoc:
        args.last.is_a?(Hash) ? args.pop : {}
      end

      VALID_FIND_OPTIONS = [:bypass_index, :conditions, :limit, :order, :offset,
                            :include, :view, :source, :fields, :num_versions, :timestamp,
                            :operator, :debug, :query_function, :include_deleted, :force_reload, :no_parsing, :columns,
                            :stop_row]

      def validate_find_options(options) #:nodoc:
        options.assert_valid_keys(VALID_FIND_OPTIONS)
      end

      def find_every_from_hbase(options)
        requested_columns = columns_to_find(options)

        raw_records = connection.get_consecutive_rows_raw(table_name, options[:offset],
          options[:limit], requested_columns, options[:stop_row])

        raw_records.collect do |raw_record|
          add_missing_cells(raw_record, requested_columns)
          rec = instantiate(raw_record)
          rec.all_attributes_loaded = true if options[:view] == :all
          rec
        end
      end

      def find_every_from_index(options)
        # Construct the query. First add the type information.
        #query = "type:#{self.name}^4 "
        query =""

        # set default operator
        options[:operator] ||= :or

        # First add the conditions predicates
        conditions = options[:conditions]
        if conditions.is_a?(String)
          query << conditions
        elsif conditions.is_a?(Array) and !conditions.empty?
          nb_conditions = conditions.size - 1
          i = 0
          query << conditions[0].gsub(/\?/) do |c|
            i += 1
            raise ArgumentError, "Missing condition argument" unless i <= nb_conditions
            "#{conditions[i]}"
          end
        elsif conditions.is_a?(Hash) and !conditions.empty?
          conditions.each do |k, v|
            query << "#{k}:#{v} "
          end
        end

        fields =
        if options[:fields]
          options[:fields]
        else
          if options[:view]
            options[:view] == :all ? ["*"] : index_views_hash[options[:view]]
          else
            index_views_hash[:default]
          end
        end
        if options[:source] == :index
          find_values_by_solr(query, :offset    =>options[:offset],
                                      :order    => options[:order],
                                      :limit    => options[:limit],
                                      :fields   => fields,
                                      :operator => options[:operator],
                                      :no_parsing => options[:no_parsing],
                                      :query_function => options[:query_function],
                                      :debug    => options[:debug]).docs
        else
          find_by_solr(query, :offset   => options[:offset],
                              :order    => options[:order],
                              :limit    => options[:limit],
                              :no_parsing => options[:no_parsing],
                              :query_function => options[:query_function],
                              :operator => options[:operator]).docs
        end
      end

      def find_all_by_id(ids, options={})
        ids.inject([]) do |result, id|
          begin
            result << find_one(id, options)
          rescue BigRecord::RecordNotFound => e
          end
          result
        end
      end

      def find_from_ids(ids, options)
        expects_array = ids.first.kind_of?(Array)
        return ids.first if expects_array && ids.first.empty?

        ids = ids.flatten.compact.uniq

        case ids.size
          when 0
            raise RecordNotFound, "Couldn't find #{name} without an ID"
          when 1
            result = find_one(ids.first, options)
            expects_array ? [ result ] : result
          else
            ids.collect do |id|
              find_one(id, options)
            end
        end
      end

      def find_one(id, options)
        # allow to pass a record (e.g. Entity.find(@entity)) and not only a string (e.g. Entity.find("$-monkey-123"))
        unless id.is_a?(String)
          id = id.id if id and not id.is_a?(String)
        end

        # Allow the client to give us other objects than integers, e.g. Time and String
        if options[:timestamp] && options[:timestamp].kind_of?(Time)
          options[:timestamp] = options[:timestamp].to_hbase_timestamp
        end

        requested_columns = columns_to_find(options)

        # TODO: this is a hack... it should be done in a single call but currently hbase doesn't allow that
        raw_record =
        if options[:num_versions] and options[:num_versions] > 1
          timestamps = connection.get(table_name, id, "attribute:updated_at", options)
          timestamps.collect{|timestamp| connection.get_columns_raw(table_name, id, requested_columns, :timestamp => timestamp.to_hbase_timestamp)}
        else
          connection.get_columns_raw(table_name, id, requested_columns, options)
        end

        # Instantiate the raw record (or records, if multiple versions were asked)
        if raw_record
          if raw_record.is_a?(Array)
            unless raw_record.empty?
              raw_record.collect do |r|
                r['attribute:id'] = id
                add_missing_cells(r, requested_columns)
                rec = instantiate(r)
                rec.all_attributes_loaded = true if options[:view] == :all
                rec
              end
            else
              raise RecordNotFound, "Couldn't find #{name} with ID=#{id}"
            end
          else
            raw_record['attribute:id'] = id
            add_missing_cells(raw_record, requested_columns)
            rec = instantiate(raw_record)
            rec.all_attributes_loaded = true if options[:view] == :all
            rec
          end
        else
          raise RecordNotFound, "Couldn't find #{name} with ID=#{id}"
        end
      end

      # return the list of columns to get from hbase
      def columns_to_find(options={})
        c =
        if options[:columns]
          options[:columns]
        elsif options[:view]
          raise ArgumentError, "Unknown view: #{options[:view]}" unless views_hash[options[:view]]
          if options[:view] == :all
            ["attribute:"]
          else
            views_hash[options[:view]].column_names
          end
        elsif views_hash[:default]
          views_hash[:default].column_names
        else
          ["attribute:"]
        end
        c += [options[:include]] if options[:include]
        c.flatten
      end

      # Add the missing cells to the raw record and set them to nil. We know that it's
      # nil because else we would have received those cells. That way, when the value of
      # one of these cells will be requested by the client we won't try to lazy load it.
      def add_missing_cells(raw_record, requested_columns)
        requested_columns.each do |k, v|
          # don't do it for column families (e.g. attribute:)
          unless k =~ /:$/
            raw_record[k] = nil unless raw_record.has_key?(k)
          end
        end
      end

      # Define aliases to the fully qualified attributes
      def alias_attribute(alias_name, fully_qualified_name)
        self.class_eval <<-EOF
          def #{alias_name}(options={})
            read_attribute("#{fully_qualified_name}", options)
          end
          def #{alias_name}=(value)
            write_attribute("#{fully_qualified_name}", value)
          end
        EOF
      end

    end

  end
end
