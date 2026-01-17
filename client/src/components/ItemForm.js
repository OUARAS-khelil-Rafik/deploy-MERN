import React, { useState } from 'react';
import './ItemForm.css';

function ItemForm({ onAddItem }) {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (!formData.name.trim()) {
      alert('Please enter an item name');
      return;
    }

    onAddItem(formData);
    setFormData({ name: '', description: '' });
  };

  return (
    <form className="item-form" onSubmit={handleSubmit}>
      <h2>Add New Item</h2>
      <div className="form-group">
        <input
          type="text"
          name="name"
          placeholder="Item name"
          value={formData.name}
          onChange={handleChange}
          className="form-input"
        />
      </div>
      <div className="form-group">
        <textarea
          name="description"
          placeholder="Item description (optional)"
          value={formData.description}
          onChange={handleChange}
          className="form-textarea"
          rows="3"
        />
      </div>
      <button type="submit" className="submit-btn">Add Item</button>
    </form>
  );
}

export default ItemForm;
