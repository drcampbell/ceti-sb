class User < ActiveRecord::Base
  enum role: [:Admin, :Teacher, :Speaker, :Both]
  after_initialize :set_default_role, :if => :new_record?
  has_many :events, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :badges
  belongs_to :school
  has_one :location, :through => :school
  has_one :location
  accepts_nested_attributes_for :location
  acts_as_taggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  searchable do
    text :name, :boost => 5
    text :job_title, :business, :school, :biography
  end

  def set_default_role
    self.role ||= :Both
  end

  def feed
    Event.where('user_id = ?', id)
  end

  def tag_list_commas
    self.tags.map(&:name).join(', ')
  end
end
