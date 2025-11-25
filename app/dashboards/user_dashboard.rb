require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # THIS WAS THE MISSING PART:
  ATTRIBUTE_TYPES = {
    membership: Field::HasOne,
    id: Field::Number,
    name: Field::String,
    email: Field::String,
    password_digest: Field::String,
    
    # We must define these types so the form knows how to render them
    password: Field::Password,
    password_confirmation: Field::Password,

    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    email
    membership
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    email
    membership
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    email
    password
    password_confirmation
  ].freeze

  # COLLECTION_FILTERS
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  def display_resource(user)
    # Use safe navigation (&.) to avoid crashing if the user has no plan yet
    plan_name = user.membership&.plan&.name || "No Plan"
    "#{user.name} (#{user.email}) - [#{plan_name}]"
  end
end