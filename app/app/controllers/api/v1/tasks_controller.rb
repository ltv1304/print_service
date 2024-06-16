module Api::V1
  class TasksController < Api::ApiController
    before_action :set_resource, only: %i[show destroy]

    def create
      @resourse = Task.new

      if @resourse.valid?
        ActiveRecord::Base.transaction do
          @resourse.save
          params[:sources].each do |ticket|
            doc = Document.find_by!(ticket:)
            @resourse.sources << doc
          end
        end

        PrintJob.perform_later(@resourse)
        render json: { ticket: @resourse.ticket }
      else
        render json: @resourse.errors
      end
    end

    def show
      render json: @resourse, adapter: :json
    end

    def destroy
      @resourse.destroy
      render json: { destroyed: @resourse.ticket }
    end

    private

    def set_resource
      @resourse = Task.find_by!(ticket: params[:ticket])
    end

    def sourses_params
      params.permit(:sources)
    end
  end
end
