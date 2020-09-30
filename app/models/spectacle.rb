class Spectacle < ApplicationRecord
  extend Forwardable

  validates :name, presence: true
  validate :validate_range

  scope :ordered, -> { order(:range) }

  def_delegator :range, :min, :start_date
  def_delegator :range, :max, :finish_date

  DATE_FORMAT = '%d.%m.%Y'

  def as_json(*)
    super.except('range', 'created_at', 'updated_at').tap do |hash|
      hash['start_date'] = start_date.strftime(DATE_FORMAT)
      hash['finish_date'] = finish_date.strftime(DATE_FORMAT)
    end
  end

  private

  def validate_range
    return errors.add(:range, :invalid_type) unless range.is_a?(Range) && start_date.is_a?(Date) && finish_date.is_a?(Date)

    errors.add(:range, :wrong_direction) unless finish_date > start_date
  end
end
