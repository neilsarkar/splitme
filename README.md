# Users

## Create

### Request: POST /users/create
<pre>
  {
    user: {
      :bank_account_number
      :bank_routing_number
      :email
      :name
      :phone_number
      :password
      :date_of_birth
      :street_address
      :zip_code
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
      :email
      :password
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
