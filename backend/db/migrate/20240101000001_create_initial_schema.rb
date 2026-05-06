class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 2

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :doctor_profiles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :specialty, null: false, default: "General"

      t.timestamps
    end

    create_table :patient_profiles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }

      t.timestamps
    end

    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { to_table: :patient_profiles, on_delete: :restrict }
      t.references :doctor, null: false, foreign_key: { to_table: :doctor_profiles, on_delete: :restrict }
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "Scheduled"
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    create_table :medical_records do |t|
      t.references :appointment, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :diagnosis, null: false
      t.text :notes, default: ""

      t.timestamps
    end

    create_table :audit_logs do |t|
      t.string :action, null: false
      t.integer :performed_by_user_id, null: false
      t.string :entity_name, null: false
      t.integer :entity_id, null: false
      t.text :metadata
      t.datetime :timestamp, null: false, default: -> { "NOW()" }

      t.timestamps
    end
    add_index :audit_logs, :entity_id
  end
end
