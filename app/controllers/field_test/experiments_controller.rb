module FieldTest
  class ExperimentsController < ActionController::Base
    layout "field_test/application"

    protect_from_forgery

    http_basic_authenticate_with name: ENV["FIELD_TEST_USERNAME"], password: ENV["FIELD_TEST_PASSWORD"] if ENV["FIELD_TEST_PASSWORD"]

    def index
      @active_experiments, @completed_experiments = FieldTest::Experiment.all.sort_by(&:id).partition { |e| e.active? }
    end

    def show
      begin
        @experiment = FieldTest::Experiment.find(params[:id])
      rescue FieldTest::ExperimentNotFound
        raise ActionController::RoutingError, "Experiment not found"
      end
    end
  end
end
