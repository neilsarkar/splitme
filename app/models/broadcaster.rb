class Broadcaster
  def initialize(plan)
    @plan = plan
  end

  def notify_plan_joined(user)
    notify_group(
      "#{@plan.title}",
      "#{user.name} is in.
       \nPrice per person: #{@plan.price_per_person_string}
       \nTotal committed: #{@plan.total_price_string}"
    )
  end

  def notify_plan_collected
    notify_group(
      "#{@plan.title}",
      "It's on.
       \nEach person paid #{@plan.price_per_person_string}."
    )
  end

  private

  def notify_creator(subject, message)
    notify(@plan.user.email, subject, message)
  end

  def notify_group(subject, message)
    notify(@plan.user.email, subject, message, cc: :all)
  end

  def notify(to, subject, message, options = {})
    mail_options = {
      to: to,
      subject: subject,
      body: message,
      from: "splitme@splitmeapp.com",
      reply_to: @plan.user.email
    }

    if options[:cc].present?
      if options[:cc] == :all
        mail_options[:cc] = all_members
      else
        mail_options[:cc] = options[:cc]
      end
    end

    Pony.mail(mail_options)
  end

  def all_members
    @plan.users.map(&:email).join(",")
  end
end
