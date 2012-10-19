**Production Base Url**

https://www.splitmeapp.com/api

**Staging Base Url**

https://splitme-b.herokuapp.com/api

# Users

## Create

### Request: POST /users
<pre>
  {
    user: {
      :bank_account_number*
      :bank_routing_number*
      :email*
      :name*
      :phone_number*
      :password*
      :date_of_birth*
      :street_address*
      :zip_code*
    }
  }
</pre>

### Response: 201
<pre>
  {
    :token
  }
</pre>

## Authenticate

### Request: POST /users/authenticate
<pre>
  {
    user: {
      :email*
      :password*
    }
  }
</pre>

### Response: 200
<pre>
  {
    :token
  }
</pre>

### Response: 404 (Email not found)

### Response: 401 (Password Incorrect)

# Plans

## Create

### Request: POST /plans
<pre>
  {
    plan: {
      :title*
      :description
      :total_price || :price_per_person
    }
  }
</pre>

### Response: 201
<pre>
  {
    :id
    :title
    :description
    :total_price
    :price_per_person
    :token
    :is_fixed_price
  }
</pre>

## Index

### Request: GET /plans

### Response: 200

<pre>
  [
    {
      :id
      :title
      :description
      :total_price
      :price_per_person
      :token
      :is_fixed_price
      :is_locked
      :is_collected
    },
    ...
  ]
</pre>

## Show

### Request: GET /plans/:id

### Response: 200

<pre>
  {
    :id
    :title
    :description
    :total_price
    :price_per_person
    :token
    :is_fixed_price
    :is_locked
    :is_collected
    :breakdown
    participants: [
      {
        :id
        :name
        :email
        :phone_number
        :card_type
        state: ("unpaid" || "failed" || "escrowed" || "collected")
      },
      ...
    ]
  }
</pre>

*Sample breakdown for fixed price*
<pre style='font-style: italic'>
[
  { people: 2, price_per_person: "$50.00", current: true }
  { people: 3, price_per_person: "$33.34", next: true }
  { people: 4, price_per_person: "$25.00" }
  { people: 5, price_per_person: "$20.00" }
  { people: 6, price_per_person: "$16.67" }
]
</pre>

*Sample breakdown for per person price*
<pre style='font-style: italic'>
[
  { people: "Any number", price_per_person: "$25.00", current: true}
]
</pre>

### Response: 404 (Plan doesn't exist or User doesn't own plan)

## Preview

### GET /plans/:plan_token/preview

### Response: 200

<pre>
  {
    :id
    :title
    :description
    :total_price
    :price_per_person
    :token
    :is_fixed_price
    :is_locked
    :is_collected
    breakdown: [
      { people: 2, price_per_person: "$100.00", current: true }
      { people: 3, price_per_person: "$50.00", next: true }
      { people: 4, price_per_person: "$33.34" }
      ...
    ]
    participants: [
      {
        :name
      },
      ...
    ]
  }
</pre>

### Response: 404 (Plan doesn't exist)

# Participants

## Create

### Request: POST /participants/:plan_token/create

<pre>
  {
    :email
    :name
    :phone_number
    :card_uri
    :card_type
  }
</pre>

### Response: 201

<pre>
  {
    :email
    :name
    :phone_number
    :card_type
  }
</pre>

### Response: 400 (Creation failed)

## Create from sign in

### Request: POST /commitments/:plan_token

<pre>
  {
    :email
    :password
  }
</pre>

### Response: 200

<pre>
  {
    :email
    :name
    :phone_number
    :card_type
  }
</pre>

### Response: 404 (email not found)
### Response: 401 (password incorrect)

# Charge

## Charge

### Request: POST /plans/:id/charge/:participant_id

### Response: 200

### Response: 409 (Card has already been charged)

<pre>
  {
    state: ("unpaid" || "failed" || "escrowed" || "collected")
  }
</pre>

### Response: 400 (Card charge failed)

# Collect

### POST /plans/:id/collect

### Response: 200

### Response: 409 (Already collected)

