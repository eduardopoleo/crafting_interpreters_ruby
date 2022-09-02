EXPRESSIONS_TEMPLATE = %{
  class Expression
  <%- types.each do |type, fields| -%>
    class <%= type.capitalize %>
      attr_reader <%= fields.map { |field| ':' + field }.join(', ') %>

      def initialize(<%= fields.map { |field| field }.join(', ') %>)
        <%- fields.each do |field| -%>
        @<%= field %> = <%= field %>
        <%- end -%>
      end

      def accept(visitor)
        visitor.visit_<%= type %>
      end
    end

  <%- end -%>
  end
}