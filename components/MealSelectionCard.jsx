import React from 'react';
import { useNavigate } from 'react-router-dom';

const MealSelectionCard = () => {
  const navigate = useNavigate();

  const handleMealClick = (mealType) => {
    navigate(`/meals/${mealType}`);
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-4">
      <h3 className="text-xl font-semibold mb-4">Today's Meals</h3>
      <div className="grid grid-cols-3 gap-4">
        <button
          onClick={() => handleMealClick('breakfast')}
          className="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center transition-colors"
        >
          <span className="block text-lg font-medium">Breakfast</span>
          <span className="text-sm text-gray-600">Select your breakfast</span>
        </button>
        
        <button
          onClick={() => handleMealClick('lunch')}
          className="bg-green-100 hover:bg-green-200 p-4 rounded-lg text-center transition-colors"
        >
          <span className="block text-lg font-medium">Lunch</span>
          <span className="text-sm text-gray-600">Select your lunch</span>
        </button>
        
        <button
          onClick={() => handleMealClick('dinner')}
          className="bg-purple-100 hover:bg-purple-200 p-4 rounded-lg text-center transition-colors"
        >
          <span className="block text-lg font-medium">Dinner</span>
          <span className="text-sm text-gray-600">Select your dinner</span>
        </button>
      </div>
    </div>
  );
};

export default MealSelectionCard; 