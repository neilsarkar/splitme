describe "SM.HomeView", ->
  it "has an informative message in it", ->
    view = new SM.HomeView
    view.render()
    expect(view.$el.html()).toContain "turds"

