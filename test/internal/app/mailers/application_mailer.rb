class ApplicationMailer < ActionMailer::Base
  default from: "from@example.org",
          to: "to@example.org",
          subject: "Hello",
          body: "World"
end
