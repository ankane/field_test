module FieldTest
  class HomeController < ActionController::Base
    layout false

    def index
      @active_experiments, @completed_experiments = FieldTest::Experiment.all.sort_by(&:id).partition { |e| e.active? }
    end
  end
end
