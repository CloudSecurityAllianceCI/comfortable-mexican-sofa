class CreateCms < ActiveRecord::Migration[5.2]

  LIMIT = 16777215

  def change
    id_type = ENV["PRIMARY_KEY_TYPE"] || :bigint

    # -- Sites -----------------------------------------------------------------
    create_table :comfy_cms_sites, id: id_type, force: true do |t|
      t.string :label,        null: false
      t.string :identifier,   null: false
      t.string :hostname,     null: false
      t.string :path
      t.string :locale,       null: false, default: "en"
      t.timestamps

      t.index :hostname
    end

    # -- Layouts ---------------------------------------------------------------
    create_table :comfy_cms_layouts, id: id_type, force: true do |t|
      t.references :site,     type: id_type, null: false
      t.references :parent,   type: id_type
      t.string  :app_layout
      t.string  :label,       null: false
      t.string  :identifier,  null: false
      t.text    :content,     limit: LIMIT
      t.text    :css,         limit: LIMIT
      t.text    :js,          limit: LIMIT
      t.integer :position,    null: false, default: 0
      t.timestamps

      t.index [:parent_id, :position]
      t.index [:site_id, :identifier], unique: true
    end

    # -- Pages -----------------------------------------------------------------
    create_table :comfy_cms_pages, id: id_type, force: true do |t|
      t.references :site,         type: id_type, null: false
      t.references :layout,       type: id_type
      t.references :parent,       type: id_type
      t.references :target_page,  type: id_type
      t.string  :label,           null: false
      t.string  :slug
      t.string  :full_path,       null: false
      t.text    :content_cache,   limit: LIMIT
      t.integer :position,        null: false, default: 0
      t.integer :children_count,  null: false, default: 0
      t.boolean :is_published,    null: false, default: true
      t.timestamps

      t.index [:site_id, :full_path]
      t.index [:parent_id, :position]
      t.index [:is_published]
    end

    # -- Translations ----------------------------------------------------------
    create_table :comfy_cms_translations, id: id_type, force: true do |t|
      t.string  :locale,    null: false
      t.references :page,   type: id_type, null: false
      t.references :layout, type: id_type
      t.string  :label,           null: false
      t.text    :content_cache,   limit: LIMIT
      t.boolean :is_published,    null: false, default: true
      t.timestamps

      t.index [:locale]
      t.index [:is_published]
    end

    # -- Fragments -------------------------------------------------------------
    create_table :comfy_cms_fragments, id: id_type, force: true do |t|
      t.references  :record,      polymorphic: true
      t.string      :identifier,  null: false
      t.string      :tag,         null: false, default: "text"
      t.text        :content,     limit: LIMIT
      t.boolean     :boolean,     null: false, default: false
      t.datetime    :datetime
      t.timestamps

      t.index [:identifier]
      t.index [:datetime]
      t.index [:boolean]
    end

    # -- Snippets --------------------------------------------------------------
    create_table :comfy_cms_snippets, id: id_type, force: true do |t|
      t.references :site,     type: id_type, null: false
      t.string  :label,       null: false
      t.string  :identifier,  null: false
      t.text    :content,     limit: LIMIT
      t.integer :position,    null: false, default: 0
      t.timestamps

      t.index [:site_id, :identifier], unique: true
      t.index [:site_id, :position]
    end

    # -- Files -----------------------------------------------------------------
    create_table :comfy_cms_files, id: id_type, force: true do |t|
      t.references :site,     type: id_type, null: false
      t.string  :label,       null: false, default: ""
      t.text    :description, limit: 2048
      t.integer :position,    null: false, default: 0
      t.timestamps

      t.index [:site_id, :position]
    end

    # -- Revisions -------------------------------------------------------------
    create_table :comfy_cms_revisions, id: id_type, force: true do |t|
      t.references :record,     type: id_type, polymorphic: true, null: false
      t.text      :data,        limit: LIMIT
      t.datetime  :created_at

      t.index [:record_type, :record_id, :created_at],
      name: "index_cms_revisions_on_rtype_and_rid_and_created_at"
    end

    # -- Categories ------------------------------------------------------------
    create_table :comfy_cms_categories, id: id_type, force: true do |t|
      t.references :site,          type: id_type, null: false
      t.string  :label,            null: false
      t.string  :categorized_type, null: false

      t.index [:site_id, :categorized_type, :label],
      unique: true,
      name:   "index_cms_categories_on_site_id_and_cat_type_and_label"
    end

    create_table :comfy_cms_categorizations, id: id_type, force: true do |t|
      t.references :category,    type: id_type, null: false
      t.references :categorized, type: id_type, null: false, polymorphic: true

      t.index [:category_id, :categorized_type, :categorized_id],
      unique: true,
      name:   "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id"
    end
  end
end
