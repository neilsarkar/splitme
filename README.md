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

### Response 200

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
    },
    ...
  ]
</pre>

## Show (PARTICIPANT DATA IS FAKE)

### Request: GET /plans/:id

### Response 200

<pre>
  {
    :id
    :title
    :description
    :total_price
    :price_per_person
    :token
    :is_fixed_price
    participants: [
      {
        :id
        :name
        :email
        :phone_number
        :card_type
      },
      ...
    ]
  }
</pre>

### Response 404 (Plan doesn't exist or User doesn't own plan)

## Collect (ALWAYS RETURNS SUCCESS)

### Request: POST /plans/:id/collect/:participant_id

### Response 200

### Response 409 (Card has already been charged)

### Response 400 (Card is invalid)
