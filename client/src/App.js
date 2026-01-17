import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';
import ItemList from './components/ItemList';
import ItemForm from './components/ItemForm';

function App() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Fetch items on component mount
  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/items');
      setItems(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch items');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddItem = async (newItem) => {
    try {
      const response = await axios.post('/api/items', newItem);
      setItems([response.data, ...items]);
    } catch (err) {
      setError('Failed to add item');
      console.error(err);
    }
  };

  const handleDeleteItem = async (id) => {
    try {
      await axios.delete(`/api/items/${id}`);
      setItems(items.filter(item => item._id !== id));
    } catch (err) {
      setError('Failed to delete item');
      console.error(err);
    }
  };

  const handleToggleComplete = async (id, completed) => {
    try {
      const response = await axios.put(`/api/items/${id}`, { completed: !completed });
      setItems(items.map(item => item._id === id ? response.data : item));
    } catch (err) {
      setError('Failed to update item');
      console.error(err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>MERN Stack Application</h1>
        <p>Running on Microsoft Azure</p>
      </header>
      
      <main className="App-main">
        <ItemForm onAddItem={handleAddItem} />
        
        {error && <div className="error-message">{error}</div>}
        
        {loading ? (
          <p className="loading">Loading items...</p>
        ) : (
          <ItemList 
            items={items} 
            onDeleteItem={handleDeleteItem}
            onToggleComplete={handleToggleComplete}
          />
        )}
      </main>
    </div>
  );
}

export default App;
