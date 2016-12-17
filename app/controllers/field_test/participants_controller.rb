module FieldTest
  class ParticipantsController < BaseController
    def show
      @participant = params[:id]
    end
  end
end
