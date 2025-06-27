/** @format */

import React, { useState } from 'react';
import { fetchNui } from '../utils/fetchNui';
import { useNuiEvent } from '../hooks/useNuiEvent';

const spawnLocations = [
    { name: 'Legion Square', coords: { x: 215.76, y: -810.12, z: 30.73 } },
    { name: 'Sandy Shores', coords: { x: 1852.12, y: 3689.4, z: 34.26 } },
    { name: 'Paleto Bay', coords: { x: -447.79, y: 6020.44, z: 31.72 } },
    { name: 'Los Santos Airport', coords: { x: -1034.56, y: -2738.12, z: 20.17 } },
    { name: 'Vespucci Beach', coords: { x: -1602.34, y: -1070.45, z: 13.15 } },
    { name: 'Downtown Vinewood', coords: { x: 110.12, y: 662.34, z: 207.12 } },
    { name: 'Mirror Park', coords: { x: 1120.45, y: -3150.67, z: -38.99 } },
    { name: 'Chumash', coords: { x: -316.45, y: 6230.12, z: 30.43 } },
    { name: 'Last Location', coords: { x: 0, y: 0, z: 0 } }, // Placeholder for last location
];

const App: React.FC = () => {
    const [visible, setVisible] = useState(false);

    useNuiEvent('setVisible', (isVisible: boolean) => {
        setVisible(isVisible);
    });

    const handleSpawn = (location: (typeof spawnLocations)[0]) => {
        fetchNui('flakey_spawnselector:spawnPlayer', { name: location.name, coords: location.coords });
    };

    return (
        visible && (
            <div className='min-h-screen bg-gradient-to-b from-red-200 to-violet-300  text-white flex flex-col items-center p-8 space-y-6'>
                <h1 className='text-3xl font-bold mb-6'>Select Spawn Location</h1>
                <div className='grid grid-cols-1 md:grid-cols-3 gap-6'>
                    {spawnLocations.map((loc, idx) => (
                        <button
                            key={idx}
                            onClick={() => handleSpawn(loc)}
                            className='bg-white/20 border-2 border-dashed border-white text-white p-6 rounded-xl w-64 text-center hover:bg-white/30 transition-all'
                        >
                            {loc.name}
                        </button>
                    ))}
                </div>
            </div>
        )
    );
};

export default App;
