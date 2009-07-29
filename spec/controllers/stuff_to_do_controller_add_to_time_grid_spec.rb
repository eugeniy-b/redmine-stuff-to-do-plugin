require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#add_to_time_grid' do
  include Redmine::I18n
  integrate_views
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project)
    User.stub!(:current).and_return(@current_user)
  end

  def do_request
    post :add_to_time_grid, {}
  end
  
  it_should_behave_like 'get_time_grid_data'

  it 'should add the issue_ids to the issues list' do
    issue101 = mock_model(Issue, :id => 101)
    Issue.should_receive(:find_by_id).with('101').and_return(issue101)

    issue102 = mock_model(Issue, :id => 102)
    Issue.should_receive(:find_by_id).with('102').and_return(issue102)
    
    post :add_to_time_grid, {:issue_ids => ['101', '102']}

    assigns[:issues].should include(issue101)
    assigns[:issues].should include(issue102)
  end

  it 'should not add duplicate issue_ids to the issues list' do
    issue101 = mock_model(Issue, :id => 101)
    Issue.should_receive(:find_by_id).at_least(:once).with('101').and_return(issue101)
    
    post :add_to_time_grid, {:issue_ids => ['101', '101']}

    assigns[:issues].should include(issue101)
    assigns[:issues].collect {|issue| issue.id == 101}.size.should eql(1)
  end

  it 'should render the time_grid partial for js' do
    post :add_to_time_grid, {:format => 'js'}
    response.should render_template('_time_grid')
  end
end


describe StuffToDoController, '#add_to_time_grid with an unauthenticated user' do
  it 'should not be successful' do
    post :add_to_time_grid, {}
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post :add_to_time_grid, {}
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end

