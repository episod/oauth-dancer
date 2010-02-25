require 'test_helper'

class ServiceProvidersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_providers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_provider" do
    assert_difference('ServiceProvider.count') do
      post :create, :service_provider => { }
    end

    assert_redirected_to service_provider_path(assigns(:service_provider))
  end

  test "should show service_provider" do
    get :show, :id => service_providers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => service_providers(:one).to_param
    assert_response :success
  end

  test "should update service_provider" do
    put :update, :id => service_providers(:one).to_param, :service_provider => { }
    assert_redirected_to service_provider_path(assigns(:service_provider))
  end

  test "should destroy service_provider" do
    assert_difference('ServiceProvider.count', -1) do
      delete :destroy, :id => service_providers(:one).to_param
    end

    assert_redirected_to service_providers_path
  end
end
