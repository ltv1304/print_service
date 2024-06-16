class TemplateTasksController < ApplicationController
  before_action :set_template, only: %i[show edit update destroy]
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def index
    @resourses = TemplateTask.ordered
  end

  def show; end

  def new
    @resourse = TemplateTask.new
  end

  def create
    @resourse = TemplateTask.new(form_params)
    if @resourse.valid?
      @resourse.save
      @resourse.create_task!
      RenderService.run!(template_task: @resourse)
      PrintJob.perform_later(@resourse.task)

      respond_to do |format|
        format.html { redirect_to tasks_path, notice: 'Template task was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Template task was successfully created.' }
        format.json { render json: { ticket: @resourse.task.ticket } }
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    if @resourse.update(form_params)
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: 'Template task was successfully updated.' }
        format.turbo_stream { flash.now[:notice] = 'Template task was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @resourse.destroy
    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'Template task was successfully destroyed.' }
      format.turbo_stream { flash.now[:notice] = 'Template task was successfully destroyed.' }
    end
  end

  private

  def set_template
    @resourse = TemplateTask.find(params[:id])
  end

  def form_params
    params.require(:template_task).permit!.dup.tap do |data|
      data[:params] = JSON.parse(data[:params])
    end
  end
end
