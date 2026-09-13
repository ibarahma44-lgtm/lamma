import { BrowserRouter, Routes, Route } from 'react-router-dom';
import EventsPage from './pages/EventsPage';
import MealsPage from './pages/MealsPage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/events" element={<EventsPage />} />
        <Route path="/meals/:mealType" element={<MealsPage />} />
        {/* ... other routes ... */}
      </Routes>
    </BrowserRouter>
  );
}

export default App; 