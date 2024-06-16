class RenderService < ActiveInteraction::Base
  object :template_task, class: TemplateTask

  def execute
    renderer = ERB.new(File.read(template_task.template.file_path))
    printed_data = renderer.result_with_hash(**template_task.params)
    io = StringIO.new printed_data
    template_task.task.source.attach(io:, filename: 'main.tex',
                                     content_type: 'text/plain')
  end
end
