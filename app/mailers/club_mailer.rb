class ClubMailer < ApplicationMailer

  def form_data(params, test = false)
    if Rails.env.development? or test
      mail_to = "dustin@wittycreative.com"
    else
      mail_to = "info@modalookbook.com"
    end

    @data = params

    mail(to: mail_to, subject: "Moda Girl Club Submission")
  end

end