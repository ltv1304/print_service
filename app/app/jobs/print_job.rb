class PrintJob < ApplicationJob
  def perform(task)
    PrintService.run!(task:)
  end
end
