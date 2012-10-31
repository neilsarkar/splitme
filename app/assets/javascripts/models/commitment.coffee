class SM.Commitment

SM.Commitment.create = (token, plan, options = {}) =>
  SM.post(
    "/plans/#{plan.get('token')}/commitments"
    {}
    {
      token: token
      success: =>
        options.success("Awesome, you're in.")
      error: (errors, code, xhr) =>
        if code == 409
          options.error("You're already in the plan, dummy!")
        else
          options.error(errors)
    }
  )
