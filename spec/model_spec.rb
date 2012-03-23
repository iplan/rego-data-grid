require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AjaxDataGrid::Model" do

  describe 'by default' do
    before :each do
      @model = AjaxDataGrid::Model.new([])
    end

    it 'should not have paging' do
      @model.has_paging?.should be_false
    end

    it 'should not have sorting' do
      @model.has_sort?.should be_false
    end
  end

  describe 'when paging enabled' do
    before :each do
      (1..13).each{|i| Factory(:article, :title => "aritlce - #{i}") }
      Article.count.should == 13
    end

    it 'should paginate active records' do
      rows = Article.scoped
      model = AjaxDataGrid::Model.new(rows, {:paging_page_size => 3})
      model.rows.size.should == 3
      model.rows.total_pages.should == 5
    end
    it 'should paginate array' do
      rows = Article.all
      rows.should be_a(Array)
      model = AjaxDataGrid::Model.new(rows, {:paging_page_size => 3})
      model.rows.size.should == 3
      model.rows.total_pages.should == 5
    end
  end

  describe 'when sorting enabled' do
    before :each do
      Article.create(:title => 'guy')
      Article.create(:title => 'alex')
      Article.create(:title => 'elina')
      Article.count.should == 3
    end
    it 'should sort active records' do
      rows = Article.scoped
      model = AjaxDataGrid::Model.new(rows, {:sort_by => :title})
      model.rows.size.should == 3
      model.rows[0].title.should =='alex'
      model.rows[1].title.should =='elina'
      model.rows[2].title.should =='guy'
    end
    it 'should sort array' do
      rows = Article.all
      rows.should be_a(Array)
      model = AjaxDataGrid::Model.new(rows, {:sort_by => :title})
      model.rows[0].title.should =='alex'
      model.rows[1].title.should =='elina'
      model.rows[2].title.should =='guy'
    end
  end

end
