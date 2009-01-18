require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :roles, :roles_users, :users

  def test_user_admin_role
    assert users(:quentin).has_role?("admin")
    assert !users(:aaron).has_role?("admin")
  end
end
