require "harness"
require "spec_helper"

describe BVT::Spec::UsersManagement::AdminUser do

  before(:each) do
    @admin_user = BVT::Harness::User.new(true)
    @test_email = "#{@admin_user.namespace}my_fake@email.address"
    @test_pwd = "test-pwd"
  end

  after(:each) do
    @admin_user.delete_user(@test_email)
  end

  it "test add-user/users/delete-user/passwd command" do
    # create user
    @admin_user.create_user(@test_email, @test_pwd)
    users_info = @admin_user.list_users
    match = false
    users_info.each do |item|
      if item[:email] == @test_email
        match = true
        break
      end
    end
    match.should be_true, "cannot find created user-email, #{@test_email}"

    # login as created user
    test_user = BVT::Harness::User.new(false, @test_email, @test_pwd)
    new_passwd = "new_P@ssw0rd"

    # change passwd
    test_user.change_passwd(new_passwd)

    # login as new passwd
    test_user2 = BVT::Harness::User.new(false, @test_email, new_passwd)
    test_user2.should_not be_nil, "Cannot login target environment
Env Target: #{test_user.target}
User Email: #{@test_email}
Passwd: #{new_passwd}"
  end

end
