class TasksController < ApplicationController
  before_action :set_resource, only: %i[show edit update destroy]

  def index
    @resourses = Task.ordered
  end

  def show; end

  def new
    @resourse = Task.new
    @resourse.sources.build
  end

  def create
    puts form_params
    @resourse = Task.new(form_params)

    if @resourse.valid?
      @resourse.save!

      PrintJob.perform_later(@resourse)

      respond_to do |format|
        format.html { redirect_to polymorphic_path(Task), notice: 'Task was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Task was successfully created.' }
        format.json { render json: { ticket: @resourse.ticket } }
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    if @resourse.update(form_params)
      respond_to do |format|
        format.html { redirect_to polymorphic_path(Task), notice: 'Task was successfully updated.' }
        format.turbo_stream { flash.now[:notice] = 'Task was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @resourse.destroy
    respond_to do |format|
      format.html { redirect_to polymorphic_path(Task), notice: 'Task was successfully destroyed.' }
      format.turbo_stream { flash.now[:notice] = 'Task was successfully destroyed.' }
    end
  end

  private

  def set_resource
    @resourse = Task.find(params[:id])
  end

  def form_params
    params.require(:task).permit(sources_attributes: [:file])
  end
end
