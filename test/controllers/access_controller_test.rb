require "test_helper"

class AccessControllerTest < ActionDispatch::IntegrationTest
  test "should get verify" do
    get access_verify_url
    assert_response :success
  end
end
