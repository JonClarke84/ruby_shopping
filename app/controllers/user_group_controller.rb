class UserGroupController < ApplicationController
  belongs_to :user
  belongs_to :group
end
