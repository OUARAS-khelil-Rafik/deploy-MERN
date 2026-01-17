import React from 'react';
import './ItemList.css';

function ItemList({ items, onDeleteItem, onToggleComplete }) {
  if (items.length === 0) {
    return (
      <div className="empty-state">
        <p>No items yet. Create one to get started!</p>
      </div>
    );
  }

  return (
    <div className="item-list">
      <h2>Items ({items.length})</h2>
      <ul className="items-container">
        {items.map(item => (
          <li key={item._id} className="item-card">
            <div className="item-content">
              <div className="item-header">
                <input
                  type="checkbox"
                  checked={item.completed}
                  onChange={() => onToggleComplete(item._id, item.completed)}
                  className="item-checkbox"
                />
                <h3 className={item.completed ? 'completed' : ''}>
                  {item.name}
                </h3>
              </div>
              {item.description && (
                <p className="item-description">{item.description}</p>
              )}
              <span className="item-date">
                {new Date(item.createdAt).toLocaleDateString()}
              </span>
            </div>
            <button
              onClick={() => onDeleteItem(item._id)}
              className="delete-btn"
              title="Delete item"
            >
              ✕
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ItemList;
