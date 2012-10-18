Base url: https://www.splitmeapp.com/api

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
      :locked
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
    :locked
    breakdown: [
      { people: 2, price_per_person: "$100.00", current: true }
      { people: 3, price_per_person: "$50.00", next: true }
      { people: 4, price_per_person: "$33.34" }
      ...
    ]
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
    :locked
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

## Collect

### POST /plans/:id/collect

### Response: 200

### Response: 409 (Already collected)

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

