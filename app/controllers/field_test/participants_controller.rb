module FieldTest
  class ParticipantsController < BaseController
    def show
      @participant = params[:id]

      # TODO better ordering
      @memberships =
        if FieldTest.legacy_participants
          FieldTest::Membership.where(participant: @participant).order(:id)
        else
          FieldTest::Membership.where(participant_id: @participant, participant_type: params[:type]).order(:id)
        end

      @events =
        if FieldTest.events_supported?
          FieldTest::Event.where(field_test_membership_id: @memberships.map(&:id)).group(:field_test_membership_id, :name).count
        else
          {}
        end
    end
  end
end
