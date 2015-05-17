module RegistrationHelper

  # Returns true if the given user is a teacher user.
  def teacher_user?(user)
    user.role == 'Teacher' || user.role == 'Both'
  end

  # Returns true if the given user is a speaker user.
  def speaker_user?(user)
    user.role == 'Speaker' || user.role == 'Both'
  end
end