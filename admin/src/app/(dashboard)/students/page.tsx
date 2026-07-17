'use client';

import React, { useState } from 'react';
import { useStudents } from '@/hooks/useStudents';
import { Search, Users, User, ArrowUpRight, GraduationCap, Building2, Trash2 } from 'lucide-react';

export default function StudentsPage() {
  const [filters, setFilters] = useState({
    search: '',
    department: 'All',
    year: 'All',
    section: 'All'
  });

  const { students, isLoading, error, stats, deleteStudent } = useStudents(filters);

  const departments = ['All', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AI&DS', 'BME', 'CHEM'];
  const years = ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'];
  const sections = ['All', 'A', 'B', 'C', 'D'];

  const handleFilterChange = (key: keyof typeof filters, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const handleDelete = async (id: string, name: string) => {
    if (window.confirm(`Are you sure you want to delete student ${name}? This action cannot be undone.`)) {
      const success = await deleteStudent(id);
      if (!success) {
        alert('Failed to delete student. Please try again.');
      }
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  return (
    <div className="min-h-screen bg-gray-950 p-8">
      {/* Page Header */}
      <div className="mb-8">
        <h1 className="text-white text-2xl font-bold">Student Directory</h1>
        <p className="text-gray-500 mt-1">View registered students by department and section</p>
      </div>


      {/* Filters Row */}
      <div className="flex flex-col md:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="text"
            placeholder="Search by name or email..."
            className="w-full bg-gray-900 border border-gray-800 text-white rounded-xl pl-12 pr-4 py-3 focus:outline-none focus:ring-2 focus:ring-green-500 transition-all placeholder:text-gray-600"
            value={filters.search}
            onChange={(e) => handleFilterChange('search', e.target.value)}
          />
        </div>
        <select
          className="bg-gray-900 border border-gray-800 text-white rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-green-500 appearance-none min-w-[140px]"
          value={filters.department}
          onChange={(e) => handleFilterChange('department', e.target.value)}
        >
          {departments.map(dept => <option key={dept} value={dept}>{dept === 'All' ? 'All Departments' : dept}</option>)}
        </select>
        <select
          className="bg-gray-900 border border-gray-800 text-white rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-green-500 appearance-none min-w-[140px]"
          value={filters.year}
          onChange={(e) => handleFilterChange('year', e.target.value)}
        >
          {years.map(year => <option key={year} value={year}>{year === 'All' ? 'All Years' : year}</option>)}
        </select>
        <select
          className="bg-gray-900 border border-gray-800 text-white rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-green-500 appearance-none min-w-[140px]"
          value={filters.section}
          onChange={(e) => handleFilterChange('section', e.target.value)}
        >
          {sections.map(sec => <option key={sec} value={sec}>{sec === 'All' ? 'All Sections' : sec}</option>)}
        </select>
      </div>

      {/* Data Table */}
      <div className="bg-gray-900 rounded-2xl overflow-hidden border border-gray-800">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-800/50 text-gray-400 uppercase text-xs tracking-wider">
                <th className="px-6 py-4 font-semibold">Name</th>
                <th className="px-6 py-4 font-semibold">Email</th>
                <th className="px-6 py-4 font-semibold">Department</th>
                <th className="px-6 py-4 font-semibold">Year</th>
                <th className="px-6 py-4 font-semibold">Section</th>
                <th className="px-6 py-4 font-semibold">Registered On</th>
                <th className="px-6 py-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-800">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-gray-500">
                    <div className="flex items-center justify-center gap-3">
                      <div className="w-5 h-5 border-2 border-green-500 border-t-transparent rounded-full animate-spin"></div>
                      Loading students...
                    </div>
                  </td>
                </tr>
              ) : error ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-red-500">
                    Error loading students: {error}
                  </td>
                </tr>
              ) : students.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-16 text-center text-gray-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-16 h-16 bg-gray-800/50 rounded-full flex items-center justify-center mb-4">
                        <User className="w-8 h-8 text-gray-600" />
                      </div>
                      <p className="text-lg font-medium text-gray-400">No students found</p>
                      <p className="text-sm mt-1">Try adjusting your filters</p>
                    </div>
                  </td>
                </tr>
              ) : (
                students.map((student) => (
                  <tr key={student.id} className="hover:bg-gray-800/30 transition-colors group">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-2 h-2 rounded-full bg-green-500"></div>
                        <span className="text-white font-medium">{student.name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-gray-400 text-sm">{student.email}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center justify-center bg-green-500/10 text-green-400 text-xs font-semibold px-2.5 py-1 rounded-full border border-green-500/20">
                        {student.department}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-gray-300 text-sm">{student.year}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-gray-300 text-sm font-bold bg-gray-800 px-2 py-1 rounded-md">
                        {student.section}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-gray-500 text-sm">
                        {formatDate(student.registeredOn || new Date().toISOString())}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-green-400 hover:text-green-300 text-sm font-medium transition-colors opacity-0 group-hover:opacity-100 focus:opacity-100">
                        View
                      </button>
                      <button 
                        onClick={() => handleDelete(student.id, student.name)}
                        className="text-red-400 hover:text-red-300 p-2 rounded-lg hover:bg-red-400/10 transition-colors opacity-0 group-hover:opacity-100 focus:opacity-100 ml-2"
                        title="Delete Student"
                      >
                        <Trash2 className="w-4 h-4 inline-block" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
