# From: http://qiita.com/kwgch/items/11d88d50bdfb183d6207
ActiveRecord::Base.send(:define_singleton_method, 'union', ->(*queries) {
  from "(#{ queries.map { |q| q.ast.to_sql }.join(' UNION ') }) AS #{self.table_name}"
})


ActiveRecord::Base.send(:define_singleton_method, 'execute', ->(query) {
  from(query.as(table_name))
})
