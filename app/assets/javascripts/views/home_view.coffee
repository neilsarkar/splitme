class SM.HomeView extends SM.BaseView
  events: {
    "click .android.icon": "showAndroid"
    "click .iphone.icon": "showiPhone"
  }

  showAndroid: =>
    @$("img.iphone:not(.icon)").hide()
    @$("img.android").show()

  showiPhone: =>
    @$("img.android:not(.icon)").hide()
    @$("img.iphone").show()

  template: """
<h1>SplitMe.</h1>

<h2> Get the app from Cam or Geoff. </h2>
<img src='/assets/testflight.png' class='iphone icon' />
<img src='/assets/android.png' class='android icon' />

<h2> Enter your bank info, super quick, no big deal, don't sue us. </h2>
<img src='/assets/register.png' class='iphone'/>
<img src='/assets/register_android.png' class='android' />

<h2> Set your price. </h2>
<img src='/assets/plan_details.png' class='iphone'/>
<img src='/assets/plan_details_android.png' class='android' />

<h2> Send the link to your friends.</h2>
<img src='/assets/link.png' class='iphone'/>
<img src='/assets/link_android.png' class='android' />

<h2> Your friends put in their credit cards. Totally legit, don't sue us.</h2>
<img src='/assets/credit_card.png' />

<h2> Charge them all, and you get the money in your bank account. Don't sue us.</h2>
<img src='/assets/collect_money.png' class='iphone'/>
<img src='/assets/collect_money_android.png' class='android' />

<h2> That's it. </h2>
<img src='/assets/soon.jpg' class='iphone' />
<img src='/assets/peaking.jpeg' class='android'/>
  """
