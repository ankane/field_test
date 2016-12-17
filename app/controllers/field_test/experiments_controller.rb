module FieldTest
  class ExperimentsController < BaseController
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
