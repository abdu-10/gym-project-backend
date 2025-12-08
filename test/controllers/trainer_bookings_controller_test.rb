require "test_helper"

class TrainerBookingsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get trainer_bookings_create_url
    assert_response :success
  end
end
