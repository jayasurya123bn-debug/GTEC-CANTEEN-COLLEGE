import { useState, useEffect, useCallback } from 'react';
import api from '@/lib/api';

export interface Student {
  id: string;
  name: string;
  email: string;
  department: string;
  year: string;
  section: string;
  registeredOn: string;
}

interface UseStudentsFilters {
  search: string;
  department: string;
  year: string;
  section: string;
}

export const useStudents = (filters: UseStudentsFilters) => {
  const [students, setStudents] = useState<Student[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [stats, setStats] = useState({
    total: 0,
    cseCount: 0,
    itCount: 0,
    firstYearCount: 0,
    activeToday: 0
  });

  const fetchStudents = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const queryParams = new URLSearchParams();
      if (filters.search) queryParams.append('search', filters.search);
      if (filters.department && filters.department !== 'All') queryParams.append('department', filters.department);
      if (filters.year && filters.year !== 'All') queryParams.append('year', filters.year);
      if (filters.section && filters.section !== 'All') queryParams.append('section', filters.section);

      const response = await api.get(`/admin/students?${queryParams.toString()}`);
      const data = response.data;
      
      const studentsList = data.students || [];
      setStudents(studentsList);
      
      setStats({
        total: studentsList.length,
        cseCount: studentsList.filter((s: Student) => s.department === 'CSE').length,
        itCount: studentsList.filter((s: Student) => s.department === 'IT').length,
        firstYearCount: studentsList.filter((s: Student) => s.year === '1st Year').length,
        activeToday: Math.floor(studentsList.length * 0.8) 
      });
    } catch (err: any) {
      setError(err.message || 'An error occurred while fetching students');
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    fetchStudents();
  }, [fetchStudents]);

  return { students, isLoading, error, stats, refetch: fetchStudents };
};
