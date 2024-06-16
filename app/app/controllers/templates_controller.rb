class TemplatesController < ApplicationController
  before_action :set_template, only: %i[show edit update destroy]

  def index
    @resourses = Template.ordered
  end

  def show; end

  def new
    @resourse = Template.new
    @resourse.build_source
  end

  def create
    @resourse = Template.new(form_params)

    if @resourse.valid?
      @resourse.save!

      respond_to do |format|
        format.html { redirect_to templates_path, notice: 'Template was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Template was successfully created.' }
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    if @resourse.update(template_params)
      respond_to do |format|
        format.html { redirect_to templates_path, notice: 'Template was successfully updated.' }
        format.turbo_stream { flash.now[:notice] = 'Template was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @resourse.destroy
    respond_to do |format|
      format.html { redirect_to templates_path, notice: 'Template was successfully destroyed.' }
      format.turbo_stream { flash.now[:notice] = 'Template was successfully destroyed.' }
    end
  end

  private

  def set_template
    @resourse = Template.find(params[:id])
  end

  def form_params
    params.require(:template).permit(:name, :description, source_attributes: [:file])
  end
end
