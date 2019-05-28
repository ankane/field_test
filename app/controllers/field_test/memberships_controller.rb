module FieldTest
  class MembershipsController < BaseController
    def update
      membership = FieldTest::Membership.find(params[:id])
      membership.update!(membership_params)
      redirect_to participant_path(membership.participant)
    end

    private

      def membership_params
        params.require(:membership).permit(:variant)
      end
  end
end
