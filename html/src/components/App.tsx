import React, { useState } from "react";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";

const spawnLocations = [
  { name: "Legion Square", coords: { x: 215.76, y: -810.12, z: 30.73 } },
  { name: "Sandy Shores", coords: { x: 1852.12, y: 3689.4, z: 34.26 } },
  { name: "Paleto Bay", coords: { x: -447.79, y: 6020.44, z: 31.72 } },
  {
    name: "Los Santos Airport",
    coords: { x: -1034.56, y: -2738.12, z: 20.17 },
  },
  { name: "Vespucci Beach", coords: { x: -1602.34, y: -1070.45, z: 13.15 } },
  { name: "Downtown Vinewood", coords: { x: 110.12, y: 662.34, z: 207.12 } },
  { name: "Mirror Park", coords: { x: 1120.45, y: -3150.67, z: -38.99 } },
  { name: "Chumash", coords: { x: -316.45, y: 6230.12, z: 30.43 } },
  { name: "Last Location", coords: { x: 0, y: 0, z: 0 } },
];

const ConfirmModal = ({
  message,
  onConfirm,
  onCancel,
}: {
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
}) => (
  <div className="fixed inset-0 flex items-center justify-center z-50">
    <div className="bg-[#1f1f2b] text-white p-6 rounded-xl border border-white/10 shadow-lg w-full max-w-md space-y-6">
      <p className="text-lg text-center font-medium">{message}</p>
      <div className="flex justify-between gap-4">
        <button
          className="flex-1 px-5 py-2 rounded-md bg-white/10 hover:bg-white/20 text-white text-sm font-semibold transition border border-white/20"
          onClick={onCancel}
        >
          Cancel
        </button>
        <button
          className="flex-1 px-5 py-2 rounded-md bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold transition border border-blue-500"
          onClick={onConfirm}
        >
          Yes, Spawn
        </button>
      </div>
    </div>
  </div>
);

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [pendingSpawn, setPendingSpawn] = useState<{
    name: string;
    coords: { x: number; y: number; z: number };
  } | null>(null);

  useNuiEvent("setVisible", (isVisible: boolean) => {
    setVisible(isVisible);
  });

  const requestSpawn = (location: (typeof spawnLocations)[0]) => {
    setPendingSpawn(location);
  };

  const confirmSpawn = () => {
    if (pendingSpawn) {
      fetchNui("flakey_spawnselector:spawnPlayer", {
        name: pendingSpawn.name,
        coords: pendingSpawn.coords,
      });
      setPendingSpawn(null);
      setVisible(false);
    }
  };

  const cancelSpawn = () => {
    setPendingSpawn(null);
  };

  return (
    visible && (
      <div className="flex h-screen w-screen text-white font-sans">
        <div className="w-1/4 p-6 pt-12 bg-[#12141b]/90 border-r border-white/10 flex flex-col justify-between">
          <div>
            <h1 className="text-3xl font-extrabold mb-6 tracking-tight text-blue-400">
              Spawn Locations
            </h1>
            <div className="space-y-3 overflow-y-auto max-h-[75vh] pr-1 custom-scroll">
              {spawnLocations.map((loc, idx) => (
                <div
                  onMouseEnter={() =>
                    fetchNui("flakey_spawnselector:focusLocation", {
                      coords: loc.coords,
                    })
                  }
                  key={idx}
                  onClick={() => requestSpawn(loc)}
                  className="p-4 rounded-md cursor-pointer border border-white/10 bg-blue-400/10 hover:bg-blue-400/20 transition-all"
                >
                  <h2 className="font-semibold text-white text-md">
                    {loc.name}
                  </h2>
                </div>
              ))}
            </div>
          </div>
        </div>

        {pendingSpawn && (
          <ConfirmModal
            message={`Are you sure you want to spawn at "${pendingSpawn.name}"?`}
            onConfirm={confirmSpawn}
            onCancel={cancelSpawn}
          />
        )}
      </div>
    )
  );
};

export default App;
