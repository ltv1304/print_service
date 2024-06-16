class PrintService < ActiveInteraction::Base
  object :task, class: Task

  def execute
    folder = "#{Time.now.strftime('%s%L')}_#{task.ticket}"
    temp_dir = "/tmp/#{folder}"
    FileUtils.mkdir(temp_dir)
    FileUtils.cp task.sources.first.path, "#{temp_dir}/main.tex"

    Dir.chdir(temp_dir) do
      `lualatex #{task.sources.first.full_name}`
      return_code = $?.to_i

      if return_code.zero?
        task.status = Task::STATUS_OK
        document = Document.create!
        document.file.attach(io: File.open("#{temp_dir}/main.pdf"),
                             filename: "#{task.sources.first.short_name}.pdf",
                             content_type: 'application/pdf')

        task.results << document
      else
        task.status = Task::STATUS_ERROR
      end
      task.save
    end

    Dir.chdir(temp_dir) do
      `zip -r ../task_#{folder}.zip .`
      return_code = $?.to_i
      if return_code.zero?
        document = Document.create!
        document.file.attach(io: File.open("/tmp/task_#{folder}.zip"),
                        filename: "task_#{folder}.zip",
                        content_type: 'application/zip')
        task.artifacts << document
      end
    end
  end
end
