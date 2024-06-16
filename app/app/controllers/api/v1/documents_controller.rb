module Api::V1
  class DocumentsController < Api::ApiController
    def load
      @resourse = Document.new(form_params)

      if @resourse.valid?
        @resourse.save

        render json: { ticket: @resourse.ticket }
      else
        render json: @resourse.errors
      end
    end

    private

    def form_params
      params.permit(:file)
    end
  end
end
