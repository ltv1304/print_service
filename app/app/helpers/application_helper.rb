module ApplicationHelper
  def templates_for_select
    Template.all.map do |item|
      [item.name, item.id]
    end
  end
end
