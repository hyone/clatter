# From: http://qiita.com/kwgch/items/11d88d50bdfb183d6207
ActiveRecord::Base.send(:define_singleton_method, 'union', ->(*queries) {
  from "(#{ queries.map { |q| q.ast.to_sql }.join(' UNION ') }) AS #{self.table_name}"
})


ActiveRecord::Base.send(:define_singleton_method, 'execute', ->(query) {
  sql = case
        when query.is_a?(String)
          query
        when query.is_a?(Array)
          sanitize_sql(query)
        when query.respond_to?(:to_sql)
          query.to_sql
        else
          raise TypeError.new('query must be String or have :to_sql method')
        end

  from "(#{ sql }) AS #{table_name}"
})
