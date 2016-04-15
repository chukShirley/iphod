defmodule Iphod.Mailer do
  use Mailgun.Client,
      domain: Application.get_env(:iphod, :mailgun_domain),
      key: Application.get_env(:iphod, :mailgun_key)

  def send_contact_me(from, subject, text) do
    send_email  to: "frpaulas@gmail.com",
                from: from,
                subject: subject,
                text: text
  end
end
