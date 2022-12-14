# Generated file with all AST expressions type

class <%= base_name.capitalize %>
<%- types.each do |type, fields| -%>
  class <%= type.split('_').collect!{ |w| w.capitalize }.join %>
    attr_reader <%= fields.map { |field| ':' + field }.join(', ') %>

    def initialize(<%= fields.map { |field| field }.join(', ') %>)
      <%- fields.each do |field| -%>
      @<%= field %> = <%= field %>
      <%- end -%>
    end

    def accept(visitor)
      visitor.visit_<%= type %>(self)
    end
  end

<%- end -%>
end